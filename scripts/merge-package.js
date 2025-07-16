#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const mainPkgPath = path.resolve('package.json');
const boilerplatePkgPath = path.resolve('boilerplate/package.json');

// Get backup directory from environment variable or create new one
const backupDir =
  process.env.BOILERPLATE_BACKUP_DIR ||
  `.boilerplate-backup-${new Date().toISOString().slice(0, 10).replace(/-/g, '')}-${new Date().toTimeString().slice(0, 8).replace(/:/g, '')}`;

const backupPath = path.join(backupDir, 'package.json');

// Create backup directory if it doesn't exist
if (!fs.existsSync(backupDir)) {
  fs.mkdirSync(backupDir, { recursive: true });
  console.log(`📁 Created backup directory: ${backupDir}`);
}

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch (e) {
    console.error(`❌ Failed to read ${file}`);
    process.exit(1);
  }
}

function mergeSection(base, update) {
  return { ...base, ...update };
}

function mergePackageJson(mainPkg, boilerplatePkg) {
  const merged = { ...mainPkg };
  const sections = ['scripts', 'dependencies', 'devDependencies', 'peerDependencies'];
  for (const section of sections) {
    merged[section] = mergeSection(mainPkg[section] || {}, boilerplatePkg[section] || {});
  }
  return merged;
}

if (!fs.existsSync(mainPkgPath) || !fs.existsSync(boilerplatePkgPath)) {
  console.error('❌ package.json or boilerplate/package.json does not exist.');
  process.exit(1);
}

const mainPkg = readJson(mainPkgPath);
const boilerplatePkg = readJson(boilerplatePkgPath);

console.log('📦 Starting package.json merge...');

// Backup package.json
fs.copyFileSync(mainPkgPath, backupPath);
console.log(`🗂️ Backed up existing package.json to ${backupPath}`);

const merged = mergePackageJson(mainPkg, boilerplatePkg);

fs.writeFileSync(mainPkgPath, JSON.stringify(merged, null, 2) + '\n');
console.log('✅ Merge completed! package.json has been merged with boilerplate.');
console.log('🚧 Please check for dependency conflicts/duplicates after merging.');
