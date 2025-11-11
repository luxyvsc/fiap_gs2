# Approval Interface - Integration Guide

This guide shows how to integrate the `approval_interface` package into other packages in the FIAP AI-Enhanced Learning Platform.

## Table of Contents
- [Overview](#overview)
- [Adding as Dependency](#adding-as-dependency)
- [Basic Integration](#basic-integration)
- [Backend Integration](#backend-integration)
- [Best Practices](#best-practices)

## Overview

The `approval_interface` package provides a complete solution for managing approval workflows. It can be used by any package that needs to display items pending approval, allow users to approve or reject items, filter items, perform bulk operations, and track approval history.

## Adding as Dependency

### For Flutter Packages

Add to your `pubspec.yaml`:

```yaml
dependencies:
  approval_interface:
    path: ../approval_interface
  
  # Required peer dependencies
  flutter_riverpod: ^2.4.0
  dio: ^5.3.3
  intl: ^0.18.1
```

## Basic Integration

### Minimal Setup

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:approval_interface/approval_interface.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ApprovalDashboardScreen(),
    );
  }
}
```

### Configure API Endpoint

```bash
flutter run --dart-define=API_BASE_URL=https://your-api.example.com
```

Or programmatically:

```dart
ProviderScope(
  overrides: [
    approvalServiceProvider.overrideWith((ref) => ApprovalService(
      baseUrl: 'https://your-api.example.com',
    )),
  ],
  child: const MyApp(),
);
```

## Backend Integration

### Required API Endpoints

Your backend must implement:

```
GET    /api/v1/approvals/pending      # List items
POST   /api/v1/approvals/{id}/approve # Approve
POST   /api/v1/approvals/{id}/reject  # Reject
PUT    /api/v1/approvals/{id}/edit    # Edit
POST   /api/v1/approvals/bulk-approve # Bulk
GET    /api/v1/approvals/history      # History
```

See the main README for detailed API specifications.

### Python Backend Example (FastAPI)

```python
from fastapi import FastAPI
from pydantic import BaseModel
from typing import Optional, List

app = FastAPI()

class ApprovalRejectRequest(BaseModel):
    reason: str

@app.get("/api/v1/approvals/pending")
async def list_pending(
    type: Optional[str] = None,
    priority: Optional[str] = None,
):
    items = await fetch_pending_items(type=type, priority=priority)
    return {"success": True, "data": items}

@app.post("/api/v1/approvals/{item_id}/approve")
async def approve_item(item_id: str):
    updated_item = await approve_approval_item(item_id)
    return {"success": True, "data": updated_item}

@app.post("/api/v1/approvals/{item_id}/reject")
async def reject_item(item_id: str, request: ApprovalRejectRequest):
    updated_item = await reject_approval_item(item_id, request.reason)
    return {"success": True, "data": updated_item}
```

## Best Practices

1. **Error Handling**: Always handle network errors gracefully
2. **Loading States**: Show progress indicators
3. **Authentication**: Restrict access by user roles
4. **Testing**: Write integration tests

For complete examples and advanced usage, see the [main README](../README.md) and [example app](../example/).
