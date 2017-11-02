# HADashboardViewer-iOS
iOS Dashboard for wall mounted displays. The actual Dashboard can be set up using [HADashboard](https://home-assistant.io/docs/ecosystem/hadashboard/)
The client implements a custom screen dimming timer and disables auto-lock of the device.

# Setup
Create a Secrets.swift file with the following content, replacing the placeholders:

```
import Foundation

struct Secrets {
    static let apiPassword = HOME_ASSISTANT_API_PASSWORD
    static let homeassistantUrl = HOME_ASSISTANT_URL
    static let dashboardUrl = HADASHBOARD_URL
}
```
