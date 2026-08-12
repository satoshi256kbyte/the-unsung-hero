const IGNORE_PATTERNS = [
  /^\.claude\/skills\/speckit-/,
  /^\.specify\/(templates|scripts|workflows|integrations)\//,
];

module.exports = {
  "*.{ts,tsx}": ["biome check --write"],
  "*.md": (files) => {
    const targets = files.filter(
      (f) => !IGNORE_PATTERNS.some((re) => re.test(f.replace(process.cwd() + "/", "")))
    );
    if (targets.length === 0) return [];
    return [`markdownlint-cli2 --fix ${targets.join(" ")}`];
  },
};
