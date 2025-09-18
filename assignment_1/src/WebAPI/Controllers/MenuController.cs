using Microsoft.AspNetCore.Mvc;
using WebAPI.Models;

namespace WebAPI.Controllers
{
    // menu controller
    [ApiController]
    [Route("api/[controller]")]
    public class MenuController : ControllerBase
    {
        // TODO: move to database later
        // first dish has to be Group42 for the assignment
        private readonly List<Dish> _dishes = new List<Dish>
        {
            new Dish
            {
                Name = "Group42",
                Price = 75  // danish kroner
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

        // get menu items
        [HttpGet]
        public ActionResult<IEnumerable<Dish>> Menu()
        {
            // maybe add filtering here later??
            return Ok(_dishes);
        }
    }
}