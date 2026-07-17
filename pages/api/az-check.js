import { execSync } from "child_process";

export default function handler(req, res) {
  try {
    const output = execSync("az version").toString().trim();
    res.status(200).json({ ok: true, azInstalled: true, output });
  } catch (err) {
    res.status(200).json({ ok: true, azInstalled: false, error: err.message });
  }
}
