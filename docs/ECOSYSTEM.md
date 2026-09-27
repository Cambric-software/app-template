# Ecosystem

How multiple Cambric applications coexist and communicate on one device.

---

## Concept

```
Cambric Local Ecosystem
│
├── Product A  (registered in shared registry)
├── Product B  (registered in shared registry)
└── Shared Registry  (Cambric/Core/Registry/)
```

Each Cambric application registers itself at startup. Applications can discover each other and optionally exchange data with explicit permission.

---

## CambricEcosystemService

Manages this application's stable local identity.

```dart
final ecosystem = CambricEcosystemService();
await ecosystem.ensureIdentity();

print(ecosystem.installationId); // 'cambric-a1b2c3d4...'
print(ecosystem.protocolVersion); // 1
```

The installation ID is:
- Generated randomly (not a hardware fingerprint)
- Stored in `Cambric/Core/Ecosystem/identity.json`
- Stable across restarts
- Regenerated if the identity file is lost or corrupt

---

## ProductRegistryService

Register this product on startup:

```dart
final registry = ProductRegistryService();

await registry.register({
  'productId': 'my-product',
  'name': 'My Product',
  'version': '1.0.0',
  'platform': 'flutter',
  'protocolVersion': 1,
  'capabilities': ['local-storage', 'updates'],
  'lastSeen': DateTime.now().toIso8601String(),
});
```

Discover all registered products:

```dart
final products = await registry.products();
```

Find products with a specific capability:

```dart
final withCache = await registry.findByCapability('cache');
```

---

## Capabilities and permissions

Applications must NOT automatically access each other's data.

Use `AccessControlService` to gate access:

```dart
final acl = AccessControlService();

// Grant Product B the ability to read shared data
acl.grant('product-b', CambricCapabilities.readSharedData);

// Check before allowing access
if (acl.can('product-b', CambricCapabilities.readSharedData)) {
  // allow
}
```

Built-in capabilities:

| Capability | Meaning |
|---|---|
| `READ_SHARED_DATA` | Read from `Cambric/Shared/Data/` |
| `WRITE_SHARED_DATA` | Write to `Cambric/Shared/Data/` |
| `REQUEST_SERVICE` | Request a service from another product |
| `EXCHANGE_DATA` | Exchange approved data |

---

## Protocol version

All products must declare a `protocolVersion`. Check compatibility before communicating:

```dart
if (product['protocolVersion'] == ecosystem.protocolVersion) {
  // compatible
}
```

Currently: protocol version `1`.

---

## Important

- Connections are never automatic
- Permissions are never implicit
- Cross-product data sharing requires explicit grants
- Removing a product unregisters it from the registry
