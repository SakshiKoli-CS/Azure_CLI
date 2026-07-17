import { execSync } from "child_process";
import fs from "fs";
import path from "path";

function checkTmpWritable() {
  const testPath = "/tmp/.launch-write-test";
  try {
    fs.writeFileSync(testPath, "ok");
    fs.unlinkSync(testPath);
    return { writable: true };
  } catch (err) {
    return { writable: false, error: err.message };
  }
}

function checkLocalAzCli() {
  const installDir = path.join(process.cwd(), "azure-cli-local");
  if (!fs.existsSync(installDir)) {
    return { installed: false, reason: "azure-cli-local directory not found at runtime" };
  }
  try {
    const cmd = `PYTHONPATH="${installDir}" HOME=/tmp python3 -c "from azure.cli.core.__main__ import main; import sys; sys.argv=['az','version']; main()"`;
    const output = execSync(cmd, { shell: "/bin/sh" }).toString().trim();
    return { installed: true, runs: true, output };
  } catch (err) {
    return { installed: true, runs: false, error: err.message };
  }
}

export default function handler(req, res) {
  res.status(200).json({
    ok: true,
    tmp: checkTmpWritable(),
    azLocal: checkLocalAzCli(),
  });
}
