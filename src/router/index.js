import { createRouter, createWebHistory } from 'vue-router'

import Planes from '../views/Planes.vue'
import Login from '../views/Login.vue'
import PlaneInfo from '../views/PlaneInfo.vue'
import Register from '@/views/Register.vue'
import PilotProfile from '@/views/PilotProfile.vue'
import RentalForm from '@/views/RentalForm.vue'
import MapTest from "@/views/MapTest.vue";
import Rentalnfo from '@/views/Rentalnfo.vue'
import AccountantProfile from '@/views/AccountantProfile.vue'
import Rentals from '@/views/Rentals.vue'
import AdminProfile from '@/views/AdminProfile.vue'
import PlaneForm from '@/views/PlaneForm.vue'

const routes = [
  {
    path: '/planes', 
    name: 'Planes',  
    component: Planes
  },
  {
    path: '/login',
    name: 'Login',
    component: Login
  },
  {
    path: '/planes/:id/',
    name: 'PlaneInfo',
    component: PlaneInfo,
  },
  {
    path: '/register',
    name: 'Register',
    component: Register
  },
  {
    path: '/profile',
    name: 'Profile',
    component: PilotProfile
  },
  {
    path: '/accountant/profile',
    name: 'AccountantProfile',
    component: AccountantProfile
  },
  {
    path: '/accountant/rentals',
    name: 'RentalsList',
    component: Rentals
  },
  {
    path: '/admin/profile',
    name: 'AdminProfile',
    component: AdminProfile
  },
  {
    path: '/admin/plane/add',
    name: 'PlaneForm',
    component: PlaneForm
  },
  {
    path: '/new/rental/:planeId',
    name: 'NewRental',
    component: RentalForm
  },
  {
    path: '/map',
    name: 'Map',
    component: MapTest
  },
  {
    path: '/rental/:id',
    name: 'Rental',
    component: Rentalnfo
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

export default router