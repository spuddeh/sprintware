# Releasing

This repo publishes the mod to **GitHub Releases** and **Nexus Mods** via
[`.github/workflows/release.yml`](.github/workflows/release.yml), driven by
[`release-manifest.json`](release-manifest.json).

Sprintware is a **CET-only mod**, so it is packaged by zipping straight from source — there is no
WolvenKit step, and the WolvenKit project it used to carry was deleted (it packed a zip of the files
that were already there). The workflow stages `contentDir` into `installDir` and zips that, so
`bin/...` lands at the zip root exactly as the game expects.

> **Sprintware is feature-complete and not under active development.** This pipeline exists so that
> *if* an update ever happens, it is one `gh release create` away — not so that one is planned.

## Artifacts

| Artifact id | What | Nexus mod | File on Nexus |
| --- | --- | --- | --- |
| `sprintware` | Sprintware | [29163](https://www.nexusmods.com/cyberpunk2077/mods/29163) | main |

## One-time setup — BOTH steps are required before the first real release

1. **API key (secret).** Create a Nexus personal API key at
   <https://www.nexusmods.com/settings/api-keys> and add it as the repository secret
   **`NEXUSMODS_API_KEY`** (Settings > Secrets and variables > Actions).

2. **File ID (manifest).** Open the mod's **Files** tab > **API Info** (or the Manage Files edit
   menu), take the ID, and replace `REPLACE_WITH_SPRINTWARE_FILE_ID` in `release-manifest.json`.

   > **Do not take this value from the public v1 API.** They are different id spaces, and the wrong
   > one looks completely plausible. The v1 API reports `file_id=143279` for Sprintware v1.0.0; the
   > value this manifest wants is the one the **API Info panel** shows, which Nexus confusingly still
   > labels **"Group ID"**. (Cross-checked against Clothing Sets Checklist, whose manifest holds
   > `2895385` while its v1 API file ids are all in the 132k–150k range — no overlap.)
   >
   > File IDs are not secret, so they live in the manifest, not in a secret. The workflow **hard-fails**
   > while the placeholder is still there, so a mistake here cannot silently ship.

## Cutting a new release

1. Commit your changes and bump the version in the mod, `@changelog.md`, and `nexus_changelog.md`.
   Run `release-check` first — it fails if the version disagrees with itself.
2. Create a GitHub Release whose **tag** is `<artifact>-v<version>`:

   ```pwsh
   gh release create sprintware-v1.1.0 --title "Sprintware v1.1.0" --notes "..."
   ```

   The body is the GitHub release notes. For the **Nexus file description** (capped at 255 chars),
   put a `<!-- nexus-description-end -->` marker on its own line — everything *before* it becomes the
   file description. Omit the marker to send none.
3. On publish the workflow parses the tag, looks the artifact up in the manifest, stages and zips it
   as `Sprintware_v<version>.zip`, attaches it to the GitHub Release, and uploads to Nexus.
4. **Manually on the Nexus page** (the API does *not* do these): bump the **Mod Version** field, add
   the changelog entry, and update the description. The upload action sets only the *file* version.

## The v1.0.0 release is backfilled, and deliberately does not touch Nexus

`scripts/backfill-releases.ps1` created the `sprintware-v1.0.0` GitHub Release from the zip that was
actually published (`_release_archive/Sprintware_v1.0.0.zip`, verified byte-identical to the current
source). Its body carries an invisible `<!-- skip-nexus -->` marker, and the workflow skips any
release containing it — **that version is already live on Nexus, and re-uploading would archive the
real file and replace it with a rebuild.**

Unlike the checklist mods, it *is* marked **Latest**: there, backfilled versions were superseded by a
newer release, so taking "Latest" would have been wrong. Here v1.0.0 **is** the current release.

## Notes

- The Nexus upload uses [`Nexus-Mods/upload-action`](https://github.com/Nexus-Mods/upload-action),
  pinned to `v1.0.0-beta.8` (the Nexus v3 upload API). beta.8's `createModFileVersion` replaces the
  old `createUpdateGroupVersion`, which Nexus **removes on 2026-09-09** — so this pin is required to
  keep uploading after that date. The API is still evaluation-only; bump the pin when a stable release
  appears, and watch for further input renames.
- `archive_existing_version: true` archives the previous file on a new upload.
- `show_requirements_pop_up: true` — Sprintware requires CET, Codeware and Native Settings.
