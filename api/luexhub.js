export default function handler(req, res) {
  const ua = req.headers["user-agent"] || "";

  // Regex check browser
  const isBrowser = /(chrome|safari|firefox|edge|coc_coc_browser|opera|edg)/i.test(ua);

  if (!isBrowser) {
    // Executor -> redirect script .lua
    res.writeHead(302, { Location: "https://luexteamscript.vercel.app/luex-bsdfhe483rfyeuiywo83rye8owy38ryeuw38r.lua" });
    res.end();
  } else {
    // Browser -> redirect UI
    res.writeHead(302, { Location: "/luex" });
    res.end();
  }
}
