// MenuController.cs - REST API controller for menu operations
// Purpose: Implements the /api/menu endpoint returning available dishes
// Part of SW4BAD Assignment 1 Part A - Web API Prototype

using Microsoft.AspNetCore.Mvc;    // Provides base controller classes and HTTP attributes
using WebAPI.Models;               // References the Dish model class

namespace WebAPI.Controllers       // Groups all API controllers
{
    /// <summary>
    /// REST API controller that handles menu-related operations for the Local Food Delivery application.
    /// Implements the menu endpoint required by SW4BAD Assignment 1 Part A.
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]  // Route template resolves to /api/menu since controller name is MenuController
    public class MenuController : ControllerBase
    {
        // Static list of dishes - hardcoded per assignment requirements
        // In production, this would typically come from a database or service layer
        // First dish must be named "Group42" to fulfill Part A assignment requirement
        private readonly List<Dish> _dishes = new List<Dish>
        {
            new Dish
            {
                Name = "Group42",         // Required first dish name per assignment specification
                Price = 75                // Price in Danish Kroner (DKK)
            },
            new Dish
            {
                Name = "Spaghetti Carbonara",  // Example dish for demonstration
                Price = 89                     // Nullable int allows dishes without prices
            },
            new Dish
            {
                Name = "Caesar Salad",
                Price = 65
            }
        };

        /// <summary>
        /// Retrieves the list of available dishes from the menu.
        /// GET endpoint: /api/menu
        /// </summary>
        /// <returns>HTTP 200 OK with JSON array of Dish objects containing name and optional price</returns>
        [HttpGet]
        public ActionResult<IEnumerable<Dish>> Menu()
        {
            return Ok(_dishes);  // ActionResult.Ok() wraps response in 200 status code with JSON serialization
        }
    }
}