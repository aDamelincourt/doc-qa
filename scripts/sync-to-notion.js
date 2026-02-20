#!/usr/bin/env node
/**
 * sync-to-notion.js — Envoie la doc QA (01, 02, 03) vers Notion avec hiérarchie
 *   Projet → EPIC (parent Jira) → US/Bug (une page par ticket).
 *
 * Prérequis : NOTION_API_KEY, NOTION_PARENT_PAGE_ID (page racine "Doc QA").
 * La page racine doit être partagée avec l'intégration Notion.
 *
 * Usage : node scripts/sync-to-notion.js [--base-dir DIR] [--dry-run]
 */

const fs = require('fs');
const path = require('path');

const NOTION_API = 'https://api.notion.com/v1';
const NOTION_VERSION = '2022-06-28';
const MAX_TEXT_CHARS = 2000; // limite Notion par bloc rich_text

function env(name) {
  const v = process.env[name];
  if (!v && (name === 'NOTION_API_KEY' || name === 'NOTION_PARENT_PAGE_ID')) {
    console.error(`Erreur : ${name} doit être défini (ou dans .env)`);
    process.exit(1);
  }
  return v || '';
}

function parseArgs() {
  const args = process.argv.slice(2);
  let baseDir = process.cwd();
  let dryRun = false;
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--base-dir' && args[i + 1]) {
      baseDir = path.resolve(args[i + 1]);
      i++;
    } else if (args[i] === '--dry-run') {
      dryRun = true;
    }
  }
  return { baseDir, dryRun };
}

async function notionFetch(method, path, body = null) {
  const token = env('NOTION_API_KEY');
  const opts = {
    method,
    headers: {
      Authorization: `Bearer ${token}`,
      'Notion-Version': NOTION_VERSION,
      'Content-Type': 'application/json',
    },
  };
  if (body) opts.body = JSON.stringify(body);
  const res = await fetch(`${NOTION_API}${path}`, opts);
  const text = await res.text();
  if (!res.ok) {
    throw new Error(`Notion API ${res.status}: ${text}`);
  }
  return text ? JSON.parse(text) : {};
}

async function getBlockChildren(blockId) {
  const data = await notionFetch('GET', `/blocks/${blockId}/children?page_size=100`);
  return data.results || [];
}

async function findChildPageByTitle(parentId, title) {
  const children = await getBlockChildren(parentId);
  for (const ch of children) {
    if (ch.type !== 'child_page' && ch.type !== 'child_database') continue;
    const t = ch.child_page?.title || ch.child_database?.title || '';
    const titleStr = Array.isArray(t) ? t.map((x) => x.plain_text).join('') : String(t);
    if (titleStr.trim() === title.trim()) return ch.id;
  }
  return null;
}

async function createPage(parentId, title, children = []) {
  const body = {
    parent: { type: 'page_id', page_id: parentId },
    properties: {
      title: {
        type: 'title',
        title: [{ type: 'text', text: { content: title.slice(0, 2000) } }],
      },
    },
  };
  if (children.length > 0) body.children = children;
  const data = await notionFetch('POST', '/pages', body);
  return data.id;
}

function richTextChunks(content) {
  const out = [];
  let rest = String(content || '').replace(/\r\n/g, '\n');
  while (rest.length > 0) {
    const chunk = rest.slice(0, MAX_TEXT_CHARS);
    rest = rest.slice(MAX_TEXT_CHARS);
    out.push({ type: 'text', text: { content: chunk } });
  }
  return out.length ? out : [{ type: 'text', text: { content: ' ' } }];
}

function blockParagraph(content) {
  return {
    object: 'block',
    type: 'paragraph',
    paragraph: { rich_text: richTextChunks(content) },
  };
}

function blockHeading2(content) {
  return {
    object: 'block',
    type: 'heading_2',
    heading_2: { rich_text: [{ type: 'text', text: { content: content.slice(0, MAX_TEXT_CHARS) } }] },
  };
}

function blockCode(content, language = 'markdown') {
  return {
    object: 'block',
    type: 'code',
    code: {
      rich_text: richTextChunks(content),
      language,
    },
  };
}

async function appendBlockChildren(blockId, children) {
  // Notion accepte jusqu'à 100 blocs par requête
  for (let i = 0; i < children.length; i += 100) {
    const slice = children.slice(i, i + 100);
    await notionFetch('PATCH', `/blocks/${blockId}/children`, { children: slice });
  }
}

function readFileSafe(filePath) {
  try {
    return fs.readFileSync(filePath, 'utf8');
  } catch {
    return '';
  }
}

function collectUsDirs(projetsDir) {
  const list = [];
  if (!fs.existsSync(projetsDir)) return list;
  const projects = fs.readdirSync(projetsDir);
  for (const project of projects) {
    const projectPath = path.join(projetsDir, project);
    if (!fs.statSync(projectPath).isDirectory()) continue;
    const entries = fs.readdirSync(projectPath);
    for (const entry of entries) {
      if (!entry.startsWith('us-')) continue;
      const usDir = path.join(projectPath, entry);
      if (!fs.statSync(usDir).isDirectory()) continue;
          const metaPath = path.join(usDir, 'meta.json');
          let meta = { projectKey: project, parentKey: null, issuetype: 'Story', ticket_key: '' };
          if (fs.existsSync(metaPath)) {
            try {
              meta = { ...meta, ...JSON.parse(fs.readFileSync(metaPath, 'utf8')) };
            } catch (_) {}
          }
          if (!meta.ticket_key) {
            const num = entry.replace(/^us-/, '');
            meta.ticket_key = `${project}-${num}`;
          }
          list.push({ usDir, ...meta });
    }
  }
  return list;
}

async function getOrCreatePage(parentId, title, dryRun) {
  if (dryRun) {
    console.log(`  [dry-run] Créerait page: ${title}`);
    return null;
  }
  if (!parentId) return null;
  const existing = await findChildPageByTitle(parentId, title);
  if (existing) return existing;
  const id = await createPage(parentId, title);
  console.log(`  Créé: ${title}`);
  return id;
}

async function main() {
  const { baseDir, dryRun } = parseArgs();
  const parentPageId = env('NOTION_PARENT_PAGE_ID').replace(/-/g, '');
  if (!parentPageId) {
    console.error('NOTION_PARENT_PAGE_ID requis (ID de la page racine Doc QA dans Notion).');
    process.exit(1);
  }

  const projetsDir = path.join(baseDir, 'projets');
  const usList = collectUsDirs(projetsDir);
  if (usList.length === 0) {
    console.log('Aucun dossier US trouvé dans projets/.');
    return;
  }

  console.log(`Sync Notion: ${usList.length} US trouvée(s), racine ${parentPageId}`);
  if (dryRun) console.log('Mode dry-run: aucune écriture Notion.\n');

  // Grouper par projet puis par EPIC (parentKey)
  const byProject = new Map();
  for (const us of usList) {
    const proj = us.projectKey || path.basename(path.dirname(us.usDir));
    if (!byProject.has(proj)) byProject.set(proj, new Map());
    const epicKey = us.parentKey || '_sans_epic_';
    if (!byProject.get(proj).has(epicKey)) byProject.get(proj).set(epicKey, []);
    byProject.get(proj).get(epicKey).push(us);
  }

  for (const [projectKey, epics] of byProject) {
    const projectTitle = `Projet ${projectKey}`;
    const projectPageId = await getOrCreatePage(parentPageId, projectTitle, dryRun);
    if (!projectPageId && !dryRun) continue;

    for (const [epicKey, tickets] of epics) {
      const epicTitle = epicKey === '_sans_epic_' ? 'Sans EPIC' : `EPIC ${epicKey}`;
      const epicPageId = await getOrCreatePage(projectPageId, epicTitle, dryRun);
      const parentForUs = epicPageId || projectPageId;

      for (const us of tickets) {
        const ticketKey = us.ticket_key;
        const typeLabel = (us.issuetype || 'Story').toLowerCase().includes('bug') ? 'Bug' : 'US';
        const pageTitle = `${typeLabel} ${ticketKey}`;

        const usPageId = await getOrCreatePage(parentForUs, pageTitle, dryRun);
        if (!usPageId && dryRun) continue;
        if (!usPageId) continue;

        const f01 = readFileSafe(path.join(us.usDir, '01-questions-clarifications.md'));
        const f02 = readFileSafe(path.join(us.usDir, '02-strategie-test.md'));
        const f03 = readFileSafe(path.join(us.usDir, '03-cas-test.md'));

        const blocks = [
          blockHeading2('01 – Questions et clarifications'),
          blockCode(f01 || '(vide)', 'markdown'),
          blockHeading2('02 – Stratégie de test'),
          blockCode(f02 || '(vide)', 'markdown'),
          blockHeading2('03 – Cas de test'),
          blockCode(f03 || '(vide)', 'markdown'),
        ];

        if (!dryRun && blocks.length > 0) {
          const existing = await getBlockChildren(usPageId);
          if (existing.length === 0) {
            await appendBlockChildren(usPageId, blocks);
            console.log(`    Contenu ajouté: ${pageTitle}`);
          } else {
            console.log(`    Déjà rempli (ignoré): ${pageTitle}`);
          }
        }
      }
    }
  }

  console.log('\nSync Notion terminé.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
