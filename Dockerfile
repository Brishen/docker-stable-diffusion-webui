FROM nvidia/cuda:11.7.1-base-ubuntu22.04

COPY entrypoint.sh /app/entrypoint.sh

RUN apt update && \
    apt install -y python3 python3-pip python3-venv python3-wheel git wget libgl1-mesa-dev libglib2.0-0 libsm6 libxrender1 libxext6 && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -g 1000 sdgroup && \
    useradd -m -s /bin/bash -u 1000 -g 1000 --home /app sduser && \
    ln -s /app /home/sduser && \
    chown -R sduser:sdgroup /app && \
    chmod +x /app/entrypoint.sh

USER sduser
WORKDIR /app

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui stable-diffusion-webui

VOLUME /app/stable-diffusion-webui/extensions
VOLUME /app/stable-diffusion-webui/models
VOLUME /app/stable-diffusion-webui/outputs
VOLUME /app/stable-diffusion-webui/localizations

EXPOSE 8080

ENV PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.9,max_split_size_mb:512
ENV TORCH_COMMAND="pip install torch torchvision torchaudio"

RUN python3 -m venv /app/stable-diffusion-webui/venv && \
    . /app/stable-diffusion-webui/venv/bin/activate && \
    pip install wheel && \
    pip install -r /app/stable-diffusion-webui/requirements_versions.txt && \
    pip install fairscale
    
ENTRYPOINT ["/app/entrypoint.sh", "--update-check", "--xformers", "--allow-code", "--enable-insecure-extension-access", "--listen", "--port", "8080"]
# CMD ["--medvram"]
