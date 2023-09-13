using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FizzBuzz.Iterators
{
    internal interface IGenerator
    {
        void Seed(int start);
        void Reset();

        string Next();
    }
}
