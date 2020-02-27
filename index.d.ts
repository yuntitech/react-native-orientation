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
