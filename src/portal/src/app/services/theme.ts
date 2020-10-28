export interface ThemeInterface {
    showStyle: string;
    mode: string;
    text: string;
    currentFileName: string;
    toggleFileName: string;
}

export const THEME_ARRAY: ThemeInterface[] = [
    {
        showStyle: "SUSE",
        mode: "SUSE",
        text: "",
        currentFileName: "suse-theme.css",
        toggleFileName: "suse-theme.css",
    }
];
