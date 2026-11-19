import { describe, it, expect } from 'vitest';
import { releaseInfo, RELEASES_URL } from '../../utils/ReleaseVersion';

describe('releaseInfo', () => {
  it('shows the deployed release tag and links to its release', () => {
    expect(releaseInfo('v2026.11.19.2', 'app-v2026.11.19.40')).toEqual({
      label: 'v2026.11.19.2',
      href: `${RELEASES_URL}/tag/v2026.11.19.2`,
    });
  });

  it('falls back to the build number when the pod has no release set', () => {
    expect(releaseInfo('', 'app-v2026.11.19.40')).toEqual({
      label: 'Build: app-v2026.11.19.40',
      href: RELEASES_URL,
    });
  });

  it('falls back when VITE_RELEASE is missing (vite dev)', () => {
    expect(releaseInfo(undefined, 'local')).toEqual({ label: 'Build: local', href: RELEASES_URL });
  });

  it('ignores anything that is not a release tag', () => {
    expect(releaseInfo('<script>', 'b').href).toBe(RELEASES_URL);
    expect(releaseInfo('app-v2026.11.19.40', 'b').label).toBe('Build: b');
    expect(releaseInfo(42, 'b').label).toBe('Build: b');
  });
});
