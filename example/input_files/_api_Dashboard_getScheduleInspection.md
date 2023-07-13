<!-- inp_uri -->
```
/api/InspectionStructure/SupplementSurveyL1/getDetailSuplementalSurveyVideo
```
<!-- /inp_uri -->

<!-- inp_curl -->
```bash
curl -X 'GET' \
  'https://example.com/api/Dashboard/getScheduleInspection?start_date=2020-07-11&end_date=2023-07-11&user_name=inspector' \
  -H 'accept: */*'
```
<!-- /inp_curl -->

<!-- inp_response -->
```json
[
    {
    "the_string_0": "",
    "the_string_1": "abc123",
    "the_number_0": 0,
    "the_number_1": 55,
    "the_number_2": 8.5,
    "the_bool_0": false,
    "the_bool_1": true,
    "the_null": null,
    "the_array": ["one", "two"],
    "the_array_1": [1, 2, 3],
    "the_array_2": [null, null, null],
    "the_object": {"a": "b"},
    "id": "abc53f97-4535-4ab2-b68f-d4cf4461fzyz",
    "tag_number": "ATK-XXXX-PSV-001",
    "location": "ATK",
    "category": "PRV",
    "inspection_number": "AA-BBBB-CCC-DDDD-PRV-2023-9",
    "maintenance_order_sap": "",
    "inspection_date": "2023-07-01T00:00:00",
    "due_date": "2023-07-31T00:00:00",
    "last_inspection_date": null,
    "inspector": "inspector",
    "reviewer": "user.1",
    "approver": "approver.1",
    "third_party_services": null,
    "remarks": "",
    "deferal_id": null,
    "status_inspection": "REVIEWED",
    "final_anomaly_category": "Minor Degredation",
    "final_findings": "-",
    "final_recommendation": "-",
    "entity_id": "B00042",
    "created_at": "2023-07-06T07:48:28.633",
    "created_by": "inspection_engineer",
    "updated_at": "2023-07-06T07:59:39.117",
    "updated_by": "user.1",
    "is_deleted": false,
    "document_url": ""
  }
]
```
<!-- /inp_response -->
