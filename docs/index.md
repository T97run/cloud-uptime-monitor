# Live Status

> The table below is fed by your AWS API. After deploy, paste your API URL where noted and this page will auto-refresh content when you reload.

<div id="status">Loading…</div>

<script>
(async () => {
  const api = "https://suxy3erbt6.execute-api.ca-central-1.amazonaws.com/status"; // Replace after Terraform outputs
  try {
    const res = await fetch(api);
    const data = await res.json();
    const when = new Date(data.timestamp * 1000).toLocaleString();
    const rows = data.results.map(r =>
      `<tr><td>${r.url}</td><td>${r.ok ? "✅" : "❌"}</td><td>${r.ms ?? "-"}</td><td>${r.error ?? ""}</td></tr>`
    ).join("");
    document.getElementById("status").innerHTML =
      `<p>Last check: <b>${when}</b></p>
       <table>
         <tr><th>URL</th><th>OK</th><th>Latency (ms)</th><th>Error</th></tr>
         ${rows}
       </table>`;
  } catch(e) {
    document.getElementById("status").textContent = "Failed to load status.";
  }
})();
</script>
