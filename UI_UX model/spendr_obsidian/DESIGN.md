# Design System Strategy: High-End Personal Finance


# NOT OBLIGED TO USE THIS TEMPLATE, THIS IS A PERSONAL PREFERENCE WHERE I MIGHT NOT ACT ACCORDINGLY IN EVERYTHING.

## 1. Overview & Creative North Star: "The Financial Sanctuary"
This design system moves away from the chaotic, "spreadsheet" feel of traditional finance apps. Our Creative North Star is **The Financial Sanctuary**. It is an environment that feels private, authoritative, and calm. 

We break the "template" look through **Intentional Asymmetry** and **Tonal Depth**. Instead of a standard grid, we use generous, unequal white space (using our `Spacing Scale`) to draw the eye to high-value data. We favor editorial-style typography—mixing the structural precision of *Inter* with the architectural elegance of *Manrope*—to make a bank statement feel like a premium lifestyle magazine.

---

## 2. Colors & Surface Philosophy
The palette is rooted in deep, obsidian tones, using the `primary` emerald for growth and `tertiary` coral for caution.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders to define sections. Boundaries must be established through background shifts. For example, a transaction list sits on `surface-container-low`, while the individual transaction items use `surface-container-highest` or simply vertical spacing.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers—like stacked sheets of tinted glass.
*   **Base:** `surface` (#10141a)
*   **Sectioning:** `surface-container-low` (#181c22)
*   **Actionable Cards:** `surface-container-high` (#262a31)
*   **Floating Elements:** `surface-bright` (#353940) with `surface_tint` (#3adfab) at 5% opacity.

### The "Glass & Gradient" Rule
To avoid a flat, "standard" dark mode, use Glassmorphism for floating headers and bottom navigation bars. Use a `backdrop-blur` of 20px combined with `surface` at 80% opacity. 
*   **Signature Textures:** For primary CTAs (like "Add Transaction"), use a linear gradient from `primary` (#42e5b0) to `primary_container` (#00c896) at a 135° angle. This provides a "glow" that flat colors cannot replicate.

---

## 3. Typography: Editorial Authority
We utilize a dual-typeface system to create a sophisticated hierarchy.

*   **Display & Headlines (Manrope):** These are our "architectural" headers. Use `display-lg` for total balance views and `headline-sm` for category titles. The wide kerning of Manrope conveys stability and wealth.
*   **Body & Labels (Inter):** Inter is our "functional" workhorse. Use `body-md` for transaction descriptions and `label-sm` (all caps, +5% tracking) for metadata like dates or timestamps.
*   **The Power Scale:** Large currency amounts should always use `headline-lg` or `display-sm` to ensure the user’s primary focus—their money—is never obscured.

---

## 4. Elevation & Depth: Tonal Layering
Traditional shadows are too heavy for a modern dark interface. We achieve lift through light, not shadow.

*   **The Layering Principle:** Depth is achieved by "stacking." Place a `surface-container-lowest` card inside a `surface-container-high` area to create an inset, "carved" look. 
*   **Ambient Shadows:** For floating action buttons or modal sheets, use a 40px blur, 0px offset shadow using `on_surface` at 4% opacity. This creates a soft "aura" rather than a drop shadow.
*   **The "Ghost Border" Fallback:** If a container lacks contrast, apply a 1px border using `outline_variant` (#3c4a43) at **15% opacity**. It should be felt, not seen.

---

## 5. Components & Interaction

### Buttons
*   **Primary:** Full-width, `xl` (1.5rem) roundedness. Gradient fill (Primary to Primary-Container). No border.
*   **Secondary:** `surface-container-highest` fill with `primary` text.
*   **Tertiary:** Transparent background, `primary` text, no border. Used for "Cancel" or "Skip."

### Cards & Lists
*   **Forbid Dividers:** Do not use lines to separate transactions. Use `spacing-3` (1rem) of vertical white space or a subtle shift from `surface-container-low` to `surface-container-high`.
*   **Rounding:** All cards must use `lg` (1rem/16px) corners to maintain a friendly, modern feel.

### Input Fields
*   **Minimalist Fields:** Use a `surface-container-lowest` background with a `ghost border` (#3c4a43 at 10%). On focus, the border transitions to 100% opacity `primary`. 
*   **Error States:** Use `error` (#ffb4ab) text and a soft `error_container` glow behind the input field.

### Data Visualization (Specific to Finance)
*   **Progress Rings:** Use `primary` for the progress and `surface-container-highest` for the "empty" track.
*   **The Pulse:** For over-budget items, use a subtle 2px outer glow (shadow) of `tertiary_container` (#ff918c) to draw attention without using "alert" icons that clutter the UI.

---

## 6. Do’s and Don’ts

### Do
*   **Do** use `spacing-8` (2.75rem) or higher for top-level page margins to create a "boutique" feel.
*   **Do** use asymmetric layouts—e.g., align "Total Balance" to the left and "Monthly Change" to the far right, separated by a large void of space.
*   **Do** use Phosphor Icons in "Light" or "Thin" weights to match the refined typography.

### Don't
*   **Don’t** use pure black (#000000). It kills the depth of the `surface` tokens.
*   **Don’t** use standard Material Design "elevated" shadows. They look muddy in dark mode.
*   **Don’t** use high-contrast white text (#FFFFFF) for everything. Use `on_surface_variant` (#bbcac1) for secondary text to reduce eye strain.
*   **Don’t** use 100% opaque red for spend amounts. Use the `tertiary` coral (#ffbbb6) for a more sophisticated, less "alarming" financial tone.