---
name: create-issue
description: Create GitHub issues using gh-issue-sync
---

# create-issue

Always use this skill when user asks to create, manage, or work with GitHub issues.

## Workflow

1. **Load gh-issue-sync skill first**: Use `skill gh-issue-sync` tool to load the skill

2. **Gather information from user**:
   - Issue title
   - Issue description (context, problem, proposed solution)
   - Labels (if any)

3. **Create local file** in `.issues/open/`:
   - Filename format: `T<hash>-<short-title>.md`
   - Include frontmatter with title and labels
   - Use markdown todo checklist for implementation plan
   - Follow sklein-issue-writing conventions

4. **Publish**: Use `gh-issue-sync push` to publish the issue

## Example

```
User: Create an issue for feature X

You: I'll create that issue using gh-issue-sync.
[skill gh-issue-sync]
[Write .issues/open/T1a2b3c-feature-x.md with frontmatter and body]
[Run gh-issue-sync push]
```

## Never

- Use `gh issue create` directly
- Create issues without gh-issue-sync
- Skip loading gh-issue-sync first

## Additional Commands

- `gh-issue-sync list` - List local issues
- `gh-issue-sync pull` - Fetch latest from remote
- `gh-issue-sync diff <number>` - Show changes