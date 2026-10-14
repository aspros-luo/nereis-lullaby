# Nereis Lullaby Cooking System Progress

## Cooking-0.2 Resource Driven Architecture

Completed:

- Ingredient resources
- Recipe resources
- Resource loader foundation
- Database loader bridge

Pipeline:

Resource (.tres)

    -> CookingResourceLoader

    -> CookingDatabaseLoader

    -> CookingManager

Future:

- Kitchen interaction
- Inventory integration
- NPC food events
- Daily schedule influence
