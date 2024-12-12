# Salesforce

The Salesforce connector enables streaming of Salesforce platform events and Change Data Capture (CDC) events by using the Faye client or Bauyex protocol. This connector also supports discovery of custom objects and properties.

## Platform Events

Salesforce platform events deliver custom event notifications when something meaningful happens to objects that are defined in your Salesforce organization. Platform Events are dynamic in nature and specific to the endpoint account connected and hence not shown in static list.

## Change Data Capture Events

Salesforce CDC events provide notifications of state changes to objects that you are interested in. Note that CDC must be enabled by customers, and it is only available for objects in the dynamic list.

## Pre-requisites

- Ensure streaming API is enabled for your Salesforce edition and organization.
- Ensure you have the required permissions set up in Salesforce to use Change Data Capture objects.
- Set the Session Security Level at login value to `None` instead of `High Assurance`.
- To connect to Salesforce sandboxes or subdomains and use Salesforce as a source application to trigger events, enable the Salesforce Organization object in your Salesforce environment.

## Authentication

The Salesforce connector supports the following authentication mechanisms:

1. Basic Oauth
2. OAuth2Password (Deprecated)

## List of static Objects and interactions supported

| **Object Name** | **Object Description** |                           **Triggers / Events**                           |
| :-------------: | :--------------------: | :-----------------------------------------------------------------------: |
|     Account     |        Account         | CREATED, UPDATED, CREATED_POLLER, UPDATED_POLLER, CREATEDORUPDATED_POLLER |
|   Attachment    |      Attachments       |                                                                           |
|     Contact     |       _Contact_        | CREATED, UPDATED, CREATED_POLLER, UPDATED_POLLER, CREATEDORUPDATED_POLLER |
| ContentDocument |    ContentDocument     |                                                                           |
|      Case       |                        |                                                                           |
|   Campaign   |                        |                                                                           |
|      Event       |                        |                                                                           |
|    File     |                        |                                                                           |
|      FileShare      |                        |                                                                           |
|     Folder      |                        |                                                                           |
|    Lead     |                        |                                                                           |
|    Order     |                        |                                                                           |
|      Opportunity      |                        |                                                                           |
|      Product2       |                        |                                                                           |
|    Solution    |                        |                                                                           |
|      Soql       |                        |                                                                           |
|      Task       |                        |              