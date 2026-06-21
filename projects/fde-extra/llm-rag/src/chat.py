import ollama

stream = ollama.chat(
    model="llama3.1",
    messages=[
        {"role": "system", "content": "You are a helpful poet assistant."},
        {"role": "user", "content": "Write a short poem, Shakespear style."},
    ],
    stream=True,
)

for chunk in stream:
    print(chunk["message"]["content"], end="", flush=True)
