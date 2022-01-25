FROM python:3.9-slim AS build-env
ADD ./app /app
WORKDIR /app
RUN python -m venv ./env \
    && . ./env/bin/activate \
    && python -m ensurepip --altinstall \
    && python -m pip install -r requirements.txt

FROM gcr.io/distroless/python3:nonroot
COPY --from=build-env /app /app

WORKDIR /app
USER 1001
ENV PATH=/app/env/bin:/usr/sbin:/usr/bin:/sbin:/bin PYTHONPATH=/app/env/lib/python3.9/site-packages

CMD ["app.py"]
