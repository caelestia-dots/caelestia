interface Colours {
    rosewater: string;
    flamingo: string;
    pink: string;
    mauve: string;
    red: string;
    maroon: string;
    peach: string;
    yellow: string;
    green: string;
    teal: string;
    sky: string;
    sapphire: string;
    blue: string;
    lavender: string;
    primary_paletteKeyColor: string;
    secondary_paletteKeyColor: string;
    tertiary_paletteKeyColor: string;
    neutral_paletteKeyColor: string;
    neutral_variant_paletteKeyColor: string;
    background: string;
    onBackground: string;
    surface: string;
    surfaceDim: string;
    surfaceBright: string;
    surfaceContainerLowest: string;
    surfaceContainerLow: string;
    surfaceContainer: string;
    surfaceContainerHigh: string;
    surfaceContainerHighest: string;
    onSurface: string;
    surfaceVariant: string;
    onSurfaceVariant: string;
    inverseSurface: string;
    inverseOnSurface: string;
    outline: string;
    outlineVariant: string;
    shadow: string;
    scrim: string;
    surfaceTint: string;
    primary: string;
    onPrimary: string;
    primaryContainer: string;
    onPrimaryContainer: string;
    inversePrimary: string;
    secondary: string;
    onSecondary: string;
    secondaryContainer: string;
    onSecondaryContainer: string;
    tertiary: string;
    onTertiary: string;
    tertiaryContainer: string;
    onTertiaryContainer: string;
    error: string;
    onError: string;
    errorContainer: string;
    onErrorContainer: string;
    primaryFixed: string;
    primaryFixedDim: string;
    onPrimaryFixed: string;
    onPrimaryFixedVariant: string;
    secondaryFixed: string;
    secondaryFixedDim: string;
    onSecondaryFixed: string;
    onSecondaryFixedVariant: string;
    tertiaryFixed: string;
    tertiaryFixedDim: string;
    onTertiaryFixed: string;
    onTertiaryFixedVariant: string;
}

interface Message {
    name: string;
    flavour: string;
    mode: "dark" | "light";
    variant: string;
    colours: Colours;
}

const browserColours = (colours: Colours) => ({
    bookmark_text: colours.onSurface,
    button_background_hover: colours.surfaceContainerHigh,
    button_background_active: colours.surfaceContainerHighest,
    icons: colours.secondary,
    icons_attention: colours.primary,
    frame: colours.surfaceDim,
    frame_inactive: colours.surfaceDim,
    tab_text: colours.onSurface,
    tab_loading: colours.primary,
    tab_background_text: colours.outline,
    tab_selected: colours.surfaceContainer,
    tab_line: colours.surfaceContainer,
    toolbar: colours.surfaceContainer,
    toolbar_text: colours.onSurface,
    toolbar_field: colours.surfaceBright,
    toolbar_field_focus: colours.surfaceBright,
    toolbar_field_border: colours.surfaceBright,
    toolbar_field_border_focus: colours.primary,
    toolbar_field_text: colours.onSurfaceVariant,
    toolbar_field_text_focus: colours.onSurface,
    toolbar_field_highlight: colours.primary,
    toolbar_field_highlight_text: colours.onPrimary,
    toolbar_field_separator: colours.surface,
    toolbar_top_separator: colours.surfaceContainer,
    toolbar_bottom_separator: colours.surface,
    toolbar_vertical_separator: colours.secondaryContainer,
    ntp_background: colours.surface,
    ntp_card_background: colours.surfaceContainer,
    ntp_text: colours.onSurface,
    popup: colours.surfaceContainer,
    popup_border: colours.outlineVariant,
    popup_text: colours.onSurface,
    popup_highlight: colours.primary,
    popup_highlight_text: colours.onPrimary,
    sidebar: colours.surfaceContainerHigh,
    sidebar_border: colours.surfaceContainerHigh,
    sidebar_text: colours.onSurface,
    sidebar_highlight: colours.secondaryContainer,
    sidebar_highlight_text: colours.onSecondaryContainer,
});

const darkReaderColours = (scheme: Message) => ({
    mode: scheme.mode === "light" ? 0 : 1,
    [`${scheme.mode}SchemeTextColor`]: `#${scheme.colours.onSurface}`,
    [`${scheme.mode}SchemeBackgroundColor`]: `#${scheme.colours.surface}`,
});

let darkReader: browser.runtime.Port | null = browser.runtime.connect("addon@darkreader.org");
darkReader.onDisconnect.addListener(() => {
    console.log("DarkReader disconnected:", darkReader?.error);
    darkReader = null;
});

browser.runtime.connectNative("caelestiafox").onMessage.addListener(msg => {
    console.log("Received message:", msg);

    const res = msg as Message;
    const colours = Object.fromEntries(Object.entries(res.colours).map(([n, c]) => [n, `#${c}`])) as unknown as Colours;
    const theme: browser._manifest.ThemeType = {
        colors: browserColours(colours),
        properties: {
            color_scheme: res.mode,
            content_color_scheme: res.mode,
        },
    };
    browser.theme.update(theme);
    console.log("Theme updated:", theme);

    if (darkReader !== null) {
        darkReader.postMessage({ type: "setTheme", data: darkReaderColours(res) });
        console.log("DarkReader theme updated.");
    }
});

console.log("CaelestiaFox started.");
