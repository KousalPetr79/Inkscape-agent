# Security policy

## Public repository policy

This is a public repository. Do not commit:

- API keys, access tokens, passwords, cookies, or session data;
- SSH, TLS, signing, or other private keys;
- `.env` files or credential exports;
- personal information or private machine paths;
- confidential SVG documents or embedded assets;
- production logs containing identifiers or authentication data.

Use synthetic examples and placeholder values only.

## Before committing

Review both tracked and untracked files:

```bash
git status --short
git diff --check
git diff --cached
```

Search staged content for credentials and private material. When available, use a dedicated scanner such as Gitleaks in addition to manual review.

## Document safety

The project controls a desktop application and can replace the active document tree. Implementations must:

- avoid overwriting unsaved user changes;
- create a backup or snapshot before destructive updates;
- validate generated SVG before loading it into Inkscape;
- present a meaningful change summary;
- verify the resulting document rather than trusting only a successful IPC response;
- restrict local bridges to the minimum required permissions.

## Reporting a vulnerability

Do not publish credentials or exploit details in a public issue. Contact the repository owner privately through an appropriate GitHub security channel. Revoke exposed credentials immediately; deleting them from the latest commit is not sufficient because Git history may retain them.
