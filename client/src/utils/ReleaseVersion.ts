// The Sidebar's version label. In prod, Terraform sets RELEASE_VERSION on the client pod per
// deploy (see .github/scripts/release-tag.sh) and Caddy serves it in /env.js as VITE_RELEASE, so
// the app shows the same vYYYY.MM.DD.N as the GitHub Release. Anywhere it isn't set (vite dev,
// a local or PR image) the label falls back to the build number baked in at build time.

export const RELEASES_URL = 'https://github.com/thermcampos/app-tasknote/releases';

const RELEASE_TAG = /^v\d{4}\.\d{2}\.\d{2}\.\d+$/;

export interface ReleaseInfo {
  label: string;
  href: string;
}

/**
 * Builds the Sidebar version label and link.
 *
 * @param {unknown} release The deployed release tag (env VITE_RELEASE), possibly empty.
 * @param {unknown} build The build number baked in at build time (env VITE_BUILD).
 * @returns {ReleaseInfo} The release tag linking to its release page, or the build number
 *   linking to the releases list.
 */
export function releaseInfo(release: unknown, build: unknown): ReleaseInfo {
  if (typeof release === 'string' && RELEASE_TAG.test(release)) {
    return { label: release, href: `${RELEASES_URL}/tag/${release}` };
  }
  return { label: `Build: ${build ?? ''}`, href: RELEASES_URL };
}
