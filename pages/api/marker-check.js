import fs from "fs";
import path from "path";

export default function handler(req, res) {
  const markerPath = path.join(process.cwd(), "build-marker.txt");
  try {
    const content = fs.readFileSync(markerPath, "utf8").trim();
    res.status(200).json({ ok: true, found: true, content, cwd: process.cwd() });
  } catch (err) {
    res.status(200).json({ ok: true, found: false, error: err.message, cwd: process.cwd() });
  }
}
