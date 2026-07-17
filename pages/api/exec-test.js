import { execSync } from "child_process";

export default function handler(req, res) {
  try {
    const output = execSync("node -v").toString().trim();
    res.status(200).json({ ok: true, output });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
}
