import { globSync, readFileSync } from "node:fs";
import { basename, dirname } from "node:path";

const skills = globSync("plugins/*/skills/*/SKILL.md").sort();
const errors = [];

for (const path of skills) {
  const frontmatter = readFileSync(path, "utf8").match(/^---\n([\s\S]*?)\n---\n/)?.[1];
  if (frontmatter === undefined) {
    errors.push(`${path}: no frontmatter`);
    continue;
  }
  const name = frontmatter.match(/^name:\s*["']?(.+?)["']?\s*$/m)?.[1];
  const dir = basename(dirname(path));
  if (name === undefined) {
    errors.push(`${path}: no name in frontmatter`);
  } else if (name !== dir) {
    errors.push(`${path}: name "${name}" does not match directory "${dir}"`);
  }
  if (!(/^name: [^"'\s]+$/m.test(frontmatter) && /^description: ".+"$/m.test(frontmatter))) {
    errors.push(`${path}: write an unquoted one-line name and a double-quoted one-line description; hooks/router.sh reads only this form`);
  }
}

if (skills.length === 0) {
  errors.push("no SKILL.md found");
}
for (const error of errors) {
  console.error(error);
}
process.exitCode = errors.length > 0 ? 1 : 0;
