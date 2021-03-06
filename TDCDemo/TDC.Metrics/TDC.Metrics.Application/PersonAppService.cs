﻿using TDC.Metrics.Application.Input;
using TDC.Metrics.Domain;

namespace TDC.Metrics.Application
{
    public class PersonAppService
    {
        public double VerifySalary(PersonInput obj)
        {
            var pessoa = new Person()
            {
                Name = obj.Name,
                Surname = obj.Surname,
                Phone = obj.Phone,
                Salary = obj.Salary
            };

            pessoa.CalculateSalary();

            if (pessoa.Salary > 1000)
            {
                pessoa.Salary = 1000;
            }

            return pessoa.Salary;
        }
    }
}
