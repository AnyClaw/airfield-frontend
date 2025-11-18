import { createRouter, createWebHistory } from 'vue-router'

import Planes from '../views/Planes.vue'
import Auth from '../views/Auth.vue'
import PlaneInfo from '../views/PlaneInfo.vue'

const routes = [
  {
    path: '/planes', 
    name: 'Planes',  
    component: Planes
  },
  {
    path: '/login',
    name: 'Login',
    component: Auth
  },
  {
    path: '/planes/:id/:plane',
    name: 'PlaneInfo',
    component: PlaneInfo,
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

export default router