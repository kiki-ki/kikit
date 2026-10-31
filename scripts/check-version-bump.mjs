import { execFileSync } from "node:child_process";
import { globSync, readFileSync } from "node:fs";
import { dirname } from "node:path";

const base = process.argv[2];
if (base === undefined) {
  console.error("usage: node scripts/check-version-bump.mjs BASE_REF");
  process.exit(2);
}

const git = (...args) => execFileSync("git", args, { encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] });
const parse = (version) => version.split(".").map(Number);
const isAbove = (a, b) => {
  for (let i = 0; i < Math.max(a.length, b.length); i++) {
    if ((a[i] ?? 0) !== (b[i] ?? 0)) return (a[i] ?? 0) > (b[i] ?? 0);
  }
  return false;
};

const mergeBase = git("merge-base", base, "HEAD").trim();
let failed = false;

for (const manifest of globSync("plugins/*/.claude-plugin/plugin.json").sort()) {
  const pluginDir = dirname(dirname(manifest));
  if (git("diff", "--name-only", mergeBase, "HEAD", "--", pluginDir).trim() === "") continue;

  const head = JSON.parse(readFileSync(manifest, "utf8")).version;
  let before;
  try {
    before = JSON.parse(git("show", `${mergeBase}:${manifest}`)).version;
  } catch {
    before = undefined;
  }

  if (head === undefined) {
    console.error(`${pluginDir}: plugin.json has no version`);
    failed = true;
  } else if (before !== undefined && !isAbove(parse(head), parse(before))) {
    console.error(`${pluginDir}: changed but version ${head} is not above ${before}; bump it in plugin.json`);
    failed = true;
  }
}

process.exitCode = failed ? 1 : 0;
