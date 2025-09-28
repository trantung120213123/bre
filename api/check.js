export default function handler(req, res) {
  const ua = req.headers["user-agent"] || "";

  // Regex check browser
  const isBrowser = /(chrome|safari|firefox|edge|coc_coc_browser|opera|edg)/i.test(ua);

  if (!isBrowser) {
    // Executor -> redirect script .lua
    res.writeHead(302, { Location: "https://youwanana.onrender.com/luex.lua" });
    res.end();
  } else {
    // Browser -> redirect UI
    res.writeHead(302, { Location: "/index.html" });
    res.end();
  }
}
