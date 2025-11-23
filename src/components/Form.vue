<template>
    <main>
        <div class="content">
            <slot></slot>
        </div>
    </main>
</template>

<style scoped>
main {
    display: flex;
    justify-content: center;
    align-items: center;
}

.content {
    min-height: 100%;
    border: 5px solid silver;
    border-radius: 10px;
    background-color: white;
    padding: 5px 10px;
    margin-top: 200px;
}
</style>