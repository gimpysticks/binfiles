#!/usr/bin/env python3
import os
import sys
import subprocess
from google import genai
from google.genai import types

# ---------------------------------------------------------
# Tool Definition
# ---------------------------------------------------------
def execute_shell_command(command: str) -> str:
    """
    Executes a bash shell command on the host Linux system.
    Returns standard output and standard error combined.
    """
    # Guardrail check for destructive operations
    blocked_patterns = ["rm -rf /", ":(){ :|:& };:", "mkfs", "dd if="]
    if any(pattern in command for pattern in blocked_patterns):
        return f"Execution blocked: Command contains unsafe pattern."

    try:
        result = subprocess.run(
            ["bash", "-c", command],
            capture_output=True,
            text=True,
            timeout=120,
            env=dict(os.environ, DEBIAN_FRONTEND="noninteractive")
        )
        output = result.stdout + result.stderr
        return output.strip() if output.strip() else "Success: Command finished with no stdout/stderr."
    except subprocess.TimeoutExpired:
        return "Error: Command execution timed out after 120 seconds."
    except Exception as exc:
        return f"Execution failed: {str(exc)}"

# ---------------------------------------------------------
# Agent Execution Loop
# ---------------------------------------------------------
def run_agent(prompt: str):
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("Error: GEMINI_API_KEY environment variable is not set.", file=sys.stderr)
        sys.exit(1)

    client = genai.Client(api_key=api_key)

    config = types.GenerateContentConfig(
        tools=[execute_shell_command],
        temperature=0.0,
        system_instruction=(
            "You are a headless, automated Linux system administrator. "
            "Convert user requests into safe, non-interactive bash commands and execute "
            "them via execute_shell_command. If a command requires root, use sudo only if needed. "
            "Summarize the final output briefly once complete."
        ),
    )

    # Initial request to Gemini
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=prompt,
        config=config,
    )

    # Handle multi-turn tool execution if Gemini issues function calls
    while response.function_calls:
        tool_responses = []
        for call in response.function_calls:
            if call.name == "execute_shell_command":
                cmd = call.args.get("command", "")
                print(f"[EXECUTING] {cmd}", file=sys.stderr)
                output = execute_shell_command(cmd)

                tool_responses.append(
                    types.Part.from_function_response(
                        name=call.name,
                        response={"result": output}
                    )
                )

        # Send tool execution results back to Gemini to get final summary or follow-up calls
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=[
                types.Content(role="user", parts=[types.Part.from_text(prompt)]),
                response.candidates[0].content,
                types.Content(role="tool", parts=tool_responses),
            ],
            config=config,
        )

    # Print final response
    if response.text:
        print(response.text)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: ./agent.py '<natural language prompt>'")
        sys.exit(1)

    user_query = " ".join(sys.argv[1:])
    run_agent(user_query)