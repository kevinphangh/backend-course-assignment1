using Microsoft.AspNetCore.Mvc;
using WebAPI.Models;

namespace WebAPI.Controllers
{
    /// <summary>
    /// Menu endpoint for SW4BAD Assignment 1 Part A
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class MenuController : ControllerBase
    {
        // Hardcoded dishes per assignment requirements
        // First dish must be "Group42" (Part A requirement)
        private readonly List<Dish> _dishes = new List<Dish>
        {
            new Dish
            {
                Name = "Group42",
                Price = 75  // DKK
            },
            new Dish
            {
                Name = "Spaghetti Carbonara",
                Price = 89
            },
            new Dish
            {
                Name = "Caesar Salad",
                Price = 65
            }
        };

        /// <summary>
        /// GET /api/menu - Returns available dishes
        /// </summary>
        [HttpGet]
        public ActionResult<IEnumerable<Dish>> Menu()
        {
            return Ok(_dishes);
        }
    }
}