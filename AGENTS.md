# AGENTS.md - sklein-devbox-chezmoi

Dotfiles configuration for [sklein-devbox](https://github.com/stephane-klein/sklein-devbox).

## Repository Structure

This is a **chezmoi-managed dotfiles repository**. The configuration is applied to the home directory when the container starts via `chezmoi apply`.

## Code Style Guidelines

### General

- **No trailing whitespace** on lines
- **No empty lines** at end of file
- **Language**: All content in English (comments, documentation, code)

## Version Control

This repository might be managed by [Jujutsu](https://jj.rs/) (jj), a decentralized version control system.

To verify if jj is used, check for a `.jj/` directory at the repo root. If jj is active, use `jj` commands instead of `git`.

## Adding New Configuration

1. Use `.tmpl` extension for templates with dynamic content
2. Add run scripts with appropriate prefixes
3. Update `.chezmoiignore` if files should not be applied
