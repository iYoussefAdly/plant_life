# Documentation

Reference material for the **Plant Life** app and the backend services it talks to.
These documents are for developers integrating with or extending the project — they
are not required to build or run the app.

| Document | Description |
|----------|-------------|
| [api_endpoints.md](api_endpoints.md) | Main Plant Life API (auth, sensors, scans, treatments, notifications) endpoint reference. |
| [BACKEND_API_REQUESTS.md](BACKEND_API_REQUESTS.md) | Outstanding backend work / API gaps that block or affect app features. |
| [PlantLife_API_Spec_Full.html](PlantLife_API_Spec_Full.html) | Full API specification (open in a browser). |

> **Note:** The app targets two backends — the main Plant Life API and a separate
> Store service. Base URLs are configured at build time via `--dart-define`; see the
> [Configuration](../README.md#configuration) section of the root README.
