using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SimpleStore.Models;

namespace SimpleStore.Controllers
{
    [Route("api/category")]
    [ApiController]
    public class CategoryController(FoodStoreContext context) : ControllerBase
    {
        private FoodStoreContext _context = context;

        [HttpGet]
        public IActionResult All()
        {
            var getCategory = _context.Categories.Select(f => new
            {
                f.CategoryId,
                f.CategoryName
            }).ToList();

            return Ok(getCategory);
        }

        [HttpGet("{categoryId}")]
        public IActionResult Detail(int categoryId)
        {
            var findProduct = _context.Categories.Find(categoryId);
            if (findProduct == null)
            {
                return NotFound(new { Message = "ID Kategori tidak ditemukan!" });
            }

            return Ok(findProduct);
        }
    }
}
