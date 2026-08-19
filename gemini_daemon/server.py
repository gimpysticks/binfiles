#!/usr/bin/env python3
import os
import subprocess
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel

app = FastAPI()

# Shared secret key to prevent unauthorized triggers
WEBHOOK_SECRET = os.environ.get("GEMINI_WEBHOOK_SECRET", "super-secret-token-123")
AGENT_BIN = os.path.expanduser("~/bin/gemini_daemon/venv/bin/python")
AGENT_SCRIPT = os.path.expanduser("~/bin/gemini_daemon/agent.py")

class CommandRequest(BaseModel):
    prompt: str

@app.post("/execute")
async def execute_instruction(payload: CommandRequest, x_auth_token: str = Header(None)):
    if x_auth_token != WEBHOOK_SECRET:
        raise HTTPException(status_code=401, detail="Unauthorized")

    try:
        # Run your Gemini daemon agent in the background
        result = subprocess.run(
            [AGENT_BIN, AGENT_SCRIPT, payload.prompt],
            capture_output=True,
            text=True,
            timeout=120
        )
        return {"status": "success", "output": result.stdout.strip()}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)