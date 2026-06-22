import json
import ollama
import sys

SYSTEM_PROMPT = "You are a helpful assistant. You will be provided with a series of messages from a conversation. Your task is to analyze the conversation and provide a thoughtful response based on the context of the messages. Please ensure that your response is relevant, coherent, and adds value to the ongoing discussion."
FILENAME = "message_history.json"
DEFAULT_MODEL = "llama3.1:latest"
MODELFILE_MODELS = {"vc-tech-expert0.1"}

def load_history(filename: str = FILENAME) -> list[dict]:
    """loads saved message history from disk, creating the file if it does not exist

    Args:
        filename (str): name of the record file storing messages history

    Returns:
        list[dict]: list of saved messages from previous conversations
    """
    try:
        with open(filename, 'r') as f:
            messages = json.load(f)
    except FileNotFoundError:
        messages = []
        save_history(messages, filename)
    return messages


def save_history(messages: list[dict], filename: str = FILENAME) -> None:
    """saves message history to disk

    Args:
        messages (list[dict]): list of messages to be saved
        filename (str): name of the record file storing messages history
    """
    with open(filename, 'w') as f:
        json.dump(messages, f, indent=4)

def clean_history(filename: str = FILENAME) -> None:
    """clears the message history file

    Args:
        filename (str): name of the record file storing messages history
    """
    save_history([], filename)


def quit_chat(messages: list[dict], filename: str = FILENAME, save: bool = False) -> None:
    """quits the chat and saves the message history if specified

    Args:
        messages (list[dict]): list of messages to be saved
        filename (str): name of the record file storing messages history
        save (bool): whether to save the message history before quitting
    """
    if save:
        save_history(messages, filename)
    print("Exiting chat. Goodbye!")
    sys.exit()

def process_request(request: str, messages: list[dict], available_models: list[str], filename: str = FILENAME, model: str = DEFAULT_MODEL) -> tuple[list[dict], str]:
    """processes user requests for saving, clearing, or quitting the chat

    Args:
        request (str): user request command
        messages (list[dict]): list of messages to be saved
        available_models (list[str]): list of available models
        filename (str): name of the record file storing messages history
        model (str): name of the model to be used for chat

    Returns:
        tuple[list[dict], str]: updated list of messages and the selected model after processing the request
    """
    if request == "/save":
        save_history(messages, filename)
        print("Message history saved.")
    elif request == "/clear":
        if model in MODELFILE_MODELS:
            messages = []
        else:
            messages = [{"role": "system", "content": SYSTEM_PROMPT}]
        clean_history(filename)
        print("Message history cleared.")
    elif request == "/quit":
        quit_chat(messages, filename)
    elif request == "/quitsave":
        quit_chat(messages, filename, save=True)
    elif request == "/selectmodel":
        print(f"Available models: {', '.join(available_models)}")
        selected_model = input("Enter the model you want to use: ")
        if selected_model in available_models:
            model = selected_model
            print(f"Model changed to '{model}'.")
        else:
            print(f"Model '{selected_model}' is not available. Available models: {', '.join(available_models)}")
    elif request == "/help":
        print("Available commands:")
        print("/save - Save the current message history to disk.")
        print("/clear - Clear the current message history.")
        print("/quit - Quit the chat without saving the message history.")
        print("/quitsave - Quit the chat saving the message history.")
        print("/selectmodel - Select a different model to use.")
    else:
        print("Invalid request. Please enter '/save', '/clear', '/quit', '/quitsave', or '/selectmodel'.")
    return messages, model


def main():
    """main function to run the chatbot"""
    messages = load_history()
    if not messages:
        messages.append({"role": "system", "content": SYSTEM_PROMPT})
        
    available_models = [m.model for m in ollama.list().models]
    model = DEFAULT_MODEL

    print("Welcome to the chatbot! Type your message and press Enter.")
    print("Type '/help' for a list of commands.")
    print(f"Selected model: '{model}'. Available models: {', '.join(available_models)}")

    while True:
        user_input = input("You: ")
        if user_input.startswith("/"):
            messages, model = process_request(user_input, messages, available_models, filename=FILENAME, model=model)
            continue
        
        messages.append({"role": "user", "content": user_input})
        stream = ollama.chat(model=model, messages=messages, stream=True)
        
        assistant_response = ""
        
        for chunk in stream:
            print(chunk["message"]["content"], end="", flush=True)
            assistant_response += chunk["message"]["content"]
            
        print()
        
        messages.append({"role": "assistant", "content": assistant_response})
        save_history(messages)

if __name__ == "__main__":
    main()
