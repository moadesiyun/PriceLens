// Adds readable checks like toBeInTheDocument() to Vitest's expect().
import "@testing-library/jest-dom/vitest";

import { afterEach } from "vitest";
import { cleanup } from "@testing-library/react";

// After each test, remove whatever was rendered, so every test
// starts with an empty page and tests can't affect each other.
afterEach(() => {
  cleanup();
});
