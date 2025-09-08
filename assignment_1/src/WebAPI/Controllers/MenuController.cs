using Microsoft.AspNetCore.Mvc;
using WebAPI.Models;

namespace WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MenuController : ControllerBase
    {
        private readonly List<Dish> _dishes = new List<Dish>
        {
            new Dish
            {
                Name = "Group42",
                Price = 75
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

        [HttpGet]
        public ActionResult<IEnumerable<Dish>> Menu()
        {
            return Ok(_dishes);
        }
    }
}