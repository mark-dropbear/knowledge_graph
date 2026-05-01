# Knowledge Graph Architecture

This document explains the architecture of the Knowledge Graph application, designed to help new developers understand how data flows, how state is managed, and how the various layers interact.

## Core Philosophy: Unified Graph State

The application operates as a local knowledge graph. Unlike traditional relational database apps that use separate tables and custom joins, this application treats everything as a node in a graph. Nodes are loosely coupled via URIs (UUIDs).

All domain models implement a base abstract class: `Thing`. This allows the entire application to use generic repositories, standard selection modals, and centralized graph resolution.

## The Layers

The application follows a clean architecture pattern with a clear separation of concerns:

### 1. Data Layer (`lib/data`)
We utilize a generic, polymorphic `data_layer` package. The entire local database is managed by a single `GraphRepository` which implements `Repository<Thing>`.

**Key Concept: `CreationBindings`**
Because the repository only knows about `Thing` objects, it uses a centralized switch statement inside `CreationBindings` to map the generic `@type` field (e.g., `Person`, `Organization`, `Action`) to specific Dart classes (`Person`, `Organization`, `Task`). This makes serialization and deserialization completely transparent to the rest of the app. 

To add a new entity type, you simply:
1. Create a model implementing `Thing`.
2. Add its `@type` mapping to `GraphRepository`'s switch cases.

### 2. Domain Layer (`lib/domain`)
The domain layer contains the definitions of our graph nodes (Models) and the business logic to mutate them (Use Cases).

*   **Models**: (e.g., `Person`, `Task`, `Organization`, `ThingInstance`). They contain purely data and `copyWith`/`toJson`/`fromJson` methods. They model relationships using Lists of Strings representing the UUIDs of connected resources (e.g., `List<String> worksFor`).
*   **Use Cases**: Rather than controllers updating models directly, all mutations happen through Use Cases. Use Cases are critical because they handle **bidirectional graph synchronization**. 
    *   *Example*: When the `EditPersonUseCase` adds an Organization to a Person's `worksFor` list, the Use Case automatically fetches the corresponding `Organization` and adds the Person's ID to its `employee` list.

### 3. Presentation Layer / ViewModels (`lib/ui`)
The UI is built with Flutter and uses the `provider` / `ListenableBuilder` pattern for reactivity via `ChangeNotifier`.

**The `GraphViewModel`**
This is the most important ViewModel in the app. It acts as a single, in-memory cache/registry for *all* loaded resources. 
*   When feature ViewModels (like `PeopleViewModel`) load data from the repository, they immediately merge those items into the central `GraphViewModel`.
*   When a UI component needs to display a relationship (e.g., a `Task` lists a `Person` as a participant), the UI asks the `GraphViewModel` to resolve the ID string back into a `Person` object.

This ensures that if a `Person`'s name is edited in the "People" tab, that name change instantly propagates to the "Tasks" tab wherever that person is referenced.

**Generic Modals & Cards**
Because everything is a `Thing`, we heavily reuse UI components:
*   `MultiTypeResourceSelectionModal`: A completely generic bottom sheet used anywhere an entity needs to link to another entity (e.g., adding assignees to a task, or colleagues to a person).
*   `PersonCard`, `OrganizationCard`, `ThingCard`: Standardized display widgets used across Detail views.

## Data Flow Example: Adding a Colleague

1.  **UI**: The user opens `PersonFormView` and taps "Edit Colleagues". The `MultiTypeResourceSelectionModal` opens, reading available people from `GraphViewModel.getItems<Person>()`.
2.  **ViewModel**: The user selects a person and saves. The UI calls `peopleViewModel.editPerson(...)`.
3.  **Use Case**: The `EditPersonUseCase` receives the new colleague list. It updates the current `Person`, then iterates through the newly added colleagues and updates *their* records to ensure the link is reciprocal. Both are saved to the `GraphRepository`.
4.  **Reactivity**: `PeopleViewModel` re-fetches the list from the database, merges the updated data into the `GraphViewModel`, and calls `notifyListeners()`. The UI automatically repaints with the new colleague cards.

## Application Initialization

In `main.dart`, all Singletons (Repository, Use Cases, ViewModels) are initialized. Crucially, the feature ViewModels eagerly load their data from the local repository on startup. This populates the central `GraphViewModel` cache so that cross-entity references resolve instantly regardless of which route the user visits first.
