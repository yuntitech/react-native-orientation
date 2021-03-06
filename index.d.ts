export function unlockAllOrientations(): void;

export function getOrientation(
  cb: (error: any, orientation: string) => void
): void;

export function addOrientationListener(cb: (orientation: string) => void): void;

export function removeOrientationListener(
  cb: (orientation: string) => void
): void;

export function lockToPortrait(): void;

export function lockToLandscape(): void;

export function lockToLandscapeRight(): void;

export function lockToLandscapeLeft(): void;

/**
 * iOS Only
 * @param supportAllOrientations 是否支持所有方向
 */
export function supportForAllOrientations(
  supportAllOrientations: boolean
): void;
