export function getLocalDateString(date: Date | number) {
    if (typeof date == "number") {
        date = new Date(date)
    }
    return `${date.getFullYear()} 年 ${date.getMonth() + 1} 月 ${date.getDate()} 日`

}

export function formatBytes(bytes: number, decimals: number) {
    if (0 == bytes)
        return "0 Bytes";
    const c = 1024, d = decimals || 2,
        e = ["Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"],
        f = Math.floor(Math.log(bytes) / Math.log(c));
    return parseFloat((bytes / Math.pow(c, f)).toFixed(d)) + " " + e[f]
}

export function randomID() {
    const S4 = () => {
            return (((1 + Math.random()) * 0x10000) | 0).toString(32).substring(1);
        };
    return S4() + S4() + S4() + S4() + S4();
}

export function cleanAllCache() {
    localStorage.clear();
    sessionStorage.clear();
    location.reload();
}
