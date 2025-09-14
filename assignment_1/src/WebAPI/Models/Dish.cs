// Dish.cs - Data model for food items in the menu
// Purpose: Defines the structure for dish objects returned by the API
// Part of SW4BAD Assignment 1 - Requires nullable Price field

namespace WebAPI.Models    // Contains all data transfer objects and models
{
    /// <summary>
    /// Data model representing a food item available for order in the Local Food Delivery system.
    /// This POCO (Plain Old CLR Object) class is used for JSON serialization/deserialization
    /// in the menu API endpoint as required by SW4BAD Assignment 1 Part A.
    /// </summary>
    public class Dish
    {
        /// <summary>
        /// The name of the dish as displayed to customers.
        /// Required field that identifies the food item (e.g., "Group42", "Spaghetti Carbonara").
        /// The first dish must be named "Group42" per assignment requirements.
        /// </summary>
        public string Name { get; set; }
        
        /// <summary>
        /// The price of the dish in Danish Kroner (DKK).
        /// Nullable integer to support dishes that may not have a fixed price
        /// or promotional items as specified in the assignment requirements.
        /// </summary>
        public int? Price { get; set; }
    }
}