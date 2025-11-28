import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:repair_shop_mobile/shared/models/models.dart';

void main() {
  test('Sale.fromJson parses sample JSON correctly', () {
    const sampleJson = '''{
  "id": 3,
  "saleNumber": "SALE-2025-0003",
  "customerId": null,
  "status": "confirmed",
  "paymentStatus": "pending",
  "subtotal": 1,
  "discountType": "percentage",
  "discountValue": 1,
  "discountAmount": 0.01,
  "taxRate": 1,
  "taxAmount": 0.99,
  "totalAmount": 1.98,
  "cogs": 0,
  "profit": 1.98,
  "notes": "r3r3",
  "saleDate": "2025-11-28T04:40:22.370Z",
  "createdAt": "2025-11-28T04:40:22.370Z",
  "updatedAt": "2025-11-28T04:56:49.873Z",
  "customer": null,
  "items": [
    {
      "id": 3,
      "saleId": 3,
      "itemId": 2,
      "quantity": 1,
      "unitPrice": 1,
      "discount": 0,
      "total": 1,
      "createdAt": "2025-11-28T04:40:22.370Z",
      "updatedAt": "2025-11-28T04:40:22.370Z",
      "item": {
        "id": 2,
        "name": "test",
        "categoryId": 1,
        "brand": "test",
        "model": "test",
        "description": null,
        "conditionId": 4,
        "qualityId": 2,
        "itemType": "other",
        "stockQuantity": 0,
        "minStockLevel": 5,
        "sellingPrice": 1,
        "createdAt": "2025-11-28T02:53:50.896Z",
        "updatedAt": "2025-11-28T04:53:13.591Z",
        "category": {
          "id": 1,
          "name": "test",
          "description": "te",
          "parentId": null,
          "createdAt": "2025-11-28T02:51:31.742Z",
          "updatedAt": "2025-11-28T02:51:31.742Z"
        },
        "condition": {
          "id": 4,
          "name": "Fair",
          "description": "Noticeable wear",
          "createdAt": "2025-11-28T02:31:01.747Z",
          "updatedAt": "2025-11-28T02:31:01.747Z"
        },
        "quality": {
          "id": 2,
          "name": "AAA",
          "description": "High quality aftermarket",
          "createdAt": "2025-11-28T02:31:01.749Z",
          "updatedAt": "2025-11-28T02:31:01.749Z"
        }
      }
    }
  ],
  "payments": []
}''';

    final saleJson = json.decode(sampleJson) as Map<String, dynamic>;
    final sale = Sale.fromJson(saleJson);

    expect(sale.id, 3);
    expect(sale.saleNumber, 'SALE-2025-0003');
    expect(sale.saleItems?.length, 1);
    expect(sale.saleItems?.first.item?.name, 'test');
  });
}
