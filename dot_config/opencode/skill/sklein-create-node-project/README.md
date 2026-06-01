# sklein-create-node-project

Skill for creating Node.js projects based on Stéphane Klein's preferences.

## Package.json Linting Rationale

This skill uses [npm-package-json-lint](https://npmpackagejsonlint.org) instead of `sort-package-json`.

**Why:**

- **Validation + Order**: Validates package.json structure AND enforces top-level property order.
- **Preserves script groupings**: sort-package-json forces alphabetical sorting of scripts, erasing intentional developer groupings. npm-package-json-lint only validates property order — scripts stay human-organized.
- **Custom order**: Enables organizing scripts by semantic family with blank lines between groups.