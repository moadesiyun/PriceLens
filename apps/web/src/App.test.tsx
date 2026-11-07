import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import App from "./App";

describe("App", () => {
  it("shows the heading", () => {
    // Arrange + Act: draw the App on the pretend page.
    render(<App />);

    // Assert: find the heading the way a user (or screen reader) would,
    // by its role and visible text.
    expect(screen.getByRole("heading", { name: "Get started" })).toBeInTheDocument();
  });

  it("increases the count when the button is clicked", async () => {
    // Arrange: render the App and set up a simulated user.
    render(<App />);
    const user = userEvent.setup();
    const button = screen.getByRole("button", { name: /count is 0/i });

    // Act: click the button like a real user.
    await user.click(button);

    // Assert: the same button now shows the new count.
    expect(button).toHaveTextContent(/count is 1/i);
  });
});
