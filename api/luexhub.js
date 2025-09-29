// luexhub.js
export default function handler(req, res) {
  const ua = req.headers["user-agent"] || "";

  // Regex check browser
  const isBrowser = /(chrome|safari|firefox|edge|coc_coc_browser|opera|edg)/i.test(ua);

  if (!isBrowser) {
    // Check for command line tools like curl, wget, powershell
    if (/curl|wget|powershell/i.test(ua)) {
      res.status(403).send("Access Denied");
    } else {
      // Executor -> redirect script .lua
      res.writeHead(302, { Location: "https://luexteamscript.vercel.app/luex-bsdfhe483rfyeuiywo83rye8owy38ryeuw38r.lua" });
      res.end();
    }
  } else {
    // Browser -> redirect UI
    res.writeHead(302, { Location: "/luex" });
    res.end();
  }
}
